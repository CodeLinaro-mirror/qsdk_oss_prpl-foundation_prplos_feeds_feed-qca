let libubus = require("ubus");
import { open, readfile } from "fs";
import { wdev_create, wdev_set_mesh_params, wdev_remove, is_equal, wdev_get_radio_mask, wdev_set_radio_mask, wdev_set_up, vlist_new, phy_open } from "common";

let ubus = libubus.connect();
let mon_ifaces = {};

wpas.data.config = {};
wpas.data.iface_phy = {};
wpas.data.macaddr_list = {};

function phy_name(phy, radio)
{
	if (!phy)
		return null;

	if (radio != null && radio >= 0)
		phy += "." + radio;

	return phy;
}

function is_ml_config(if_name, radio_id) {

	if (radio_id == -1)
		return false;

	for (let phy, config in wpas.data.config) {
		wpas.printf(`[debug] ml config check with phy:${phy} radio:${radio_id}`);
		if (config == null || config.radio == radio_id)
			continue;

		for (let ifname in config.data) {
			let data = config.data[ifname];
			if (ifname == if_name) {
				if (data.config.mld == null)
					return false;

				if (data.running == null || data.running == false)
					continue;
				wpas.printf(`[debug] ml configuration is true for ${if_name}`);
				return true;
			}
		}
	}

	return false;
}

function iface_stop(iface, radio)
{
	let ifname = iface.config.iface;

	if (!iface.running)
		return;

	if (radio == null)
		radio = -1;

	let iface_data = wpas.interfaces[ifname];

	delete wpas.data.iface_phy[ifname];
	if (!is_ml_config(ifname, radio)) {
		wpas.printf(`[debug] Removing interface ${ifname} ${radio}`);
		wpas.remove_iface(ifname, radio);
		wdev_remove(ifname);
	}

	iface.running = false;
}

function iface_start(phydev, iface, macaddr_list)
{
	let phy = phydev.name;
	let radio = phydev.radio;
	let ifname = iface.config.iface;

	wpas.printf(`[debug] [iface_start] for ${ifname} radio index ${phydev.radio} running ${iface.running}`);

	if (radio == null)
		radio = -1;

	if (is_ml_config(ifname, radio)) {
		// Setting radio_mask even interface is running is allowed.
		let radio_mask = wdev_get_radio_mask(ifname);

		if (radio_mask == null) {
			wpas.printf(`[error] [iface_start] Failed to get radio mask for ${ifname}`);
			return null;
		}

		// Configure the radio mask for each radio during BSS creation
		radio_mask = (radio_mask | (1 << phydev.radio));
		wdev_set_radio_mask(ifname, radio_mask);
		wpas.printf(`[debug] [iface_start] preserving radio mask ${radio_mask} for ML BSS ${ifname} radio index ${phydev.radio}`);
	}

	if (iface.running)
		return;

	let wdev_config = {};
	for (let field in iface.config)
		wdev_config[field] = iface.config[field];
	if (!wdev_config.macaddr)
		wdev_config.macaddr = phydev.macaddr_next();

	wpas.data.iface_phy[ifname] = phy;

	if (!is_ml_config(ifname, radio)) {
		wdev_remove(ifname);
		wpas.printf(`[debug] Create device started ${ifname} ${radio}  ${wdev_config.macaddr}`);
		let ret = phydev.wdev_add(ifname, wdev_config);
		if (ret)
			wpas.printf(`[iface_start] Failed to create device ${ifname}: ${ret}`);
	}
	wdev_set_up(ifname, true);
	wpas.add_iface(iface.config, radio);
	iface.running = true;
}

function iface_cb(new_if, old_if)
{
	if (old_if && new_if && is_equal(old_if.config, new_if.config)) {
		new_if.running = old_if.running;
		return;
	}

	if (new_if && old_if)
		wpas.printf(`Update configuration for interface ${old_if.config.iface}`);
	else if (old_if)
		wpas.printf(`Remove interface ${old_if.config.radio}`);

	if (old_if)
		iface_stop(old_if, old_if.config.radio);
}

function prepare_config(config, radio)
{
	config.config_data = readfile(config.config);

	return { config };
}

function set_config(config_name, phy_name, radio, num_global_macaddr, config_list)
{
	let phy = wpas.data.config[config_name];

	if (radio < 0)
		radio = null;

	if (!phy) {
		phy = vlist_new(iface_cb, false);
		phy.name = phy_name;
		wpas.data.config[config_name] = phy;
	}

	phy.radio = radio;
	phy.num_global_macaddr = num_global_macaddr;

	let values = [];
	for (let config in config_list)
		push(values, [ config.iface, prepare_config(config) ]);

	phy.update(values);
}

function start_pending(phy_name)
{
	let phy = wpas.data.config[phy_name];
	let ubus = wpas.data.ubus;

	if (!phy || !phy.data)
		return;

	let phydev = phy_open(phy.name, phy.radio);
	if (!phydev) {
		wpas.printf(`Could not open phy ${phy_name}`);
		return;
	}

	let macaddr_list = wpas.data.macaddr_list[phy_name];
	phydev.macaddr_init(macaddr_list, { num_global: phy.num_global_macaddr });

	for (let ifname in phy.data)
		iface_start(phydev, phy.data[ifname]);
}


function get_sta_channel_info_per_band(band)
{
	/* band: 0 = 2G, 1 = 5G, 2 = 6G */
	wpas.printf(`get_sta_channel_info_per_band: band=${band}`);
	for (let phy_name, phy_data in wpas.data.config) {
		if (!phy_data || !phy_data.data)
			continue;

		for (let ifname in phy_data.data) {
			let iface_data = phy_data.data[ifname];
			if (!iface_data || !iface_data.config)
				continue;

			if (iface_data.config.mode != "sta")
				continue;

			if (!wpas.interfaces) {
				wpas.printf(`get_sta_channel_info_per_band: `
					    `wpas.interfaces is null`);
				continue;
			}

			let iface = wpas.interfaces[ifname];
			if (!iface) {
				wpas.printf(`get_sta_channel_info_per_band: `
					    `no iface object for ${ifname}`);
				continue;
			}

			/* Log and use configured radio if present, else 0 */
			let cfg_radio = iface_data.config.radio;
			let radio = cfg_radio != null ? cfg_radio : 0;
			wpas.printf(`get_sta_channel_info_per_band: ${ifname} `
				    `cfg_radio=${cfg_radio} using_radio=${radio}`);

			let status = iface.status(radio);
			if (!status) {
				wpas.printf(`get_sta_channel_info_per_band: ${ifname} `
					    `status(null) on radio ${radio}`);
				continue;
			}

			wpas.printf(`get_sta_channel_info_per_band: ${ifname} status on `
				    `radio ${radio}: state=${status.state} `
				    `freq=${status.frequency}`);

			/* STRICT: only accept if STA is COMPLETED */
			if (status.state != "COMPLETED") {
				wpas.printf(`get_sta_channel_info_per_band: `
					    `${ifname} not COMPLETED`);
				continue;
			}

			let freq = status.frequency;
			if (freq == null) {
				wpas.printf(`get_sta_channel_info_per_band: `
					    `${ifname} has no frequency`);
				continue;
			}

			if (band == 0 && !(freq >= 2400 && freq <= 2484))
				continue;
			if (band == 1 && !(freq >= 5150 && freq <= 5885))
				continue;
			if (band == 2 && !(freq >= 5935 && freq <= 7115))
				continue;

			let bandwidth;
			switch (status.chan_width) {
			case 0: /* CHAN_WIDTH_20_NOHT */
			case 1: /* CHAN_WIDTH_20 */
				bandwidth = 20;
				break;
			case 2: /* CHAN_WIDTH_40 */
				bandwidth = 40;
				break;
			case 3: /* CHAN_WIDTH_80 */
				bandwidth = 80;
				break;
			case 4: /* CHAN_WIDTH_80P80 */
				/* Effective per-segment bandwidth is 80 MHz */
				bandwidth = 80;
				break;
			case 5: /* CHAN_WIDTH_160 */
				bandwidth = 160;
				break;
			case 10: /* CHAN_WIDTH_320 */
				bandwidth = 320;
				break;
			default:
				/* Very wide EHT widths or UNKNOWN */
				bandwidth = null;
				break;
			}

			let result = {
				frequency: status.frequency,
				bandwidth: bandwidth,
				sec_channel_offset: status.sec_chan_offset,
				center_freq1: status.center_freq1,
				center_freq2: status.center_freq2,
				punct_bitmap: status.punct_bitmap
			};
                        wpas.printf(`get_sta_channel_info_per_band: `
				    `${ifname} COMPLETED: ${result}`);
                        return result;
                }
        }

        return null;
}

let main_obj = {
	phy_set_state: {
		args: {
			phy: "",
			radio: 0,
			stop: true,
		},
		call: function(req) {
			let name = phy_name(req.args.phy, req.args.radio);
			if (!name || req.args.stop == null)
				return libubus.STATUS_INVALID_ARGUMENT;

			let phy = wpas.data.config[name];
			if (!phy)
				return libubus.STATUS_NOT_FOUND;

			try {
				if (req.args.stop) {
					for (let ifname in phy.data)
						iface_stop(phy.data[ifname], req.args.radio);
				} else {
					start_pending(name);
				}
			} catch (e) {
				wpas.printf(`Error chaging state: ${e}\n${e.stacktrace[0].context}`);
				return libubus.STATUS_INVALID_ARGUMENT;
			}
			return 0;
		}
	},
	phy_set_macaddr_list: {
		args: {
			phy: "",
			radio: 0,
			macaddr: [],
		},
		call: function(req) {
			let phy = phy_name(req.args.phy, req.args.radio);
			if (!phy)
				return libubus.STATUS_INVALID_ARGUMENT;

			wpas.data.macaddr_list[phy] = req.args.macaddr;
			return 0;
		}
	},
	phy_status: {
		args: {
			phy: "",
			radio: 0,
		},
		call: function(req) {
			let phy = phy_name(req.args.phy, req.args.radio);
			if (!phy)
				return libubus.STATUS_INVALID_ARGUMENT;

			phy = wpas.data.config[phy];
			if (!phy)
				return libubus.STATUS_NOT_FOUND;

			for (let ifname in phy.data) {
				try {
					let iface = wpas.interfaces[ifname];
					if (!iface)
						continue;

					let status = iface.status(req.args.radio);
					if (!status)
						continue;

					if (status.state == "INTERFACE_DISABLED")
						continue;

					status.ifname = ifname;
					return status;
				} catch (e) {
					continue;
				}
			}

			return libubus.STATUS_NOT_FOUND;
		}
	},
	get_sta_channel_per_band: {
		args: {
			band: 0,
		},
		call: function(req) {
			let band = req.args.band;
			wpas.printf(`get_sta_channel_per_band ubus call: band=${band}`);

			if (band == null)
				return libubus.STATUS_INVALID_ARGUMENT;

			try {
				let info = get_sta_channel_info_per_band(band);
				wpas.printf(`get_sta_channel_per_band ubus call: info=${info}`);
				if (!info)
					return libubus.STATUS_NOT_FOUND;
				return { channel_info: info };
			} catch (e) {
				wpas.printf(`get_sta_channel_info_per_band call exception: ${e}`);
				if (e && e.stacktrace && e.stacktrace[0])
					wpas.printf(`get_sta_channel_info_per_band ubus `
						    `stack: ${e.stacktrace[0].context}`);
				return libubus.STATUS_UNKNOWN_ERROR;
			}
		}
	},
	config_set: {
		args: {
			phy: "",
			radio: 0,
			num_global_macaddr: 0,
			is_ml: false,
			config: [],
			defer: true,
			mon_if_name: "",
		},
		call: function(req) {
			let phy = phy_name(req.args.phy, req.args.radio);
			if (!phy)
				return libubus.STATUS_INVALID_ARGUMENT;

			wpas.printf(`Set new config for phy ${phy} ${req.args.defer} ${req.args.config}`);

			if (req.args.mon_if_name != null)
				mon_ifaces[req.args.radio] = req.args.mon_if_name;

			try {
				if (req.args.config)
					set_config(phy, req.args.phy, req.args.radio, req.args.num_global_macaddr, req.args.config);

				if (!req.args.defer) {
					start_pending(phy);
				}
			} catch (e) {
				wpas.printf(`Error loading config: ${e}\n${e.stacktrace[0].context}`);
				return libubus.STATUS_INVALID_ARGUMENT;
			}

			return {
				pid: wpas.getpid()
			};
		}
	},
	config_add: {
		args: {
			driver: "",
			iface: "",
			bridge: "",
			hostapd_ctrl: "",
			ctrl: "",
			config: "",
		},
		call: function(req) {
			if (!req.args.iface || !req.args.config)
				return libubus.STATUS_INVALID_ARGUMENT;

			if (wpas.add_iface(req.args) < 0)
				return libubus.STATUS_INVALID_ARGUMENT;

			return {
				pid: wpas.getpid()
			};
		}
	},
	config_remove: {
		args: {
			iface: ""
		},
		call: function(req) {
			if (!req.args.iface)
				return libubus.STATUS_INVALID_ARGUMENT;

			wpas.remove_iface(req.args.iface);
			return 0;
		}
	},
	bss_info: {
		args: {
			iface: "",
		},
		call: function(req) {
			let ifname = req.args.iface;
			if (!ifname)
				return libubus.STATUS_INVALID_ARGUMENT;

			let iface = wpas.interfaces[ifname];
			if (!iface)
				return libubus.STATUS_NOT_FOUND;

			let status = iface.ctrl("STATUS");
			if (!status)
				return libubus.STATUS_NOT_FOUND;

			let ret = {};
			status = split(status, "\n");
			for (let line in status) {
				line = split(line, "=", 2);
				ret[line[0]] = line[1];
			}

			return ret;
		}
	},
	csa_finish_event: {
		args: {
			freq: 0
		},
		call: function(req) {
			wpas.printf(`csa_finish_event req.args.freq ${req.args.freq}`);
			wpas.recvd_ch_sw_comp_ev(req.args.freq);
			return 0;
		}
	},
	start_scan_post_acs: {
		args: {
			success: 0
		},
		call: function(req) {
			wpas.printf(`start_scan_post_acs received from rptr_mgr with status: ${req.args.success}`);
			wpas.start_scan_post_acs();
			return 0;
		}
	},
	uplink_csa_notify: {
		args: {
			phy: "",
			radio: 0,
			frequency: 0,
			channel: 0,
			csa_count: 0,
			new_ch_width: 0,
			ch_seg_0: 0,
			ch_seg_1: 0,
		},
		call: function(req) {
			wpas.printf(`uplink_csa_notify received for ${req.args.phy} ${req.args.radio}`);
			if (!req.args.frequency)
				return libubus.STATUS_INVALID_ARGUMENT;

			let phy_data = wpas.data.config[req.args.phy];
			if (!phy_data) {
				wpas.printf(`uplink_csa_notify: interface not found`);
				return libubus.STATUS_INVALID_ARGUMENT;
			}

			let ret = false;
			for (let ifname in phy_data.data) {
				let iface = wpas.interfaces[ifname];
				if (!iface)
					continue;
				let status = iface.status(req.args.radio);
				if (!status)
					continue;
				wpas.printf(`uplink_csa_notify: state is ${status.state} ${req.args.csa}`);
				if (status.state == "INTERFACE_DISABLED")
					continue;
				let freq_info = {};
				freq_info.frequency = req.args.frequency;
				freq_info.csa_count = req.args.csa_count ?? 10;
				freq_info.channel = req.args.channel;
				freq_info.new_ch_width = req.args.new_ch_width;
				freq_info.ch_seg_0 = req.args.ch_seg_0;
				freq_info.ch_seg_1 = req.args.ch_seg_1;
				wpas.printf(`notify: freq_info ${freq_info}`);
				ret = iface.notify_uplink_csa(freq_info);
			}
			if (!ret)
				return libubus.STATUS_UNKNOWN_ERROR;
			return 0;
		}
	},
	disconnect_request: {
		args: {
			phy: "",
			radio: 0,
		},
		call: function(req) {
			wpas.printf(`reconnect request received for ${req.args.phy} ${req.args.radio}`);
			let phy_data = wpas.data.config[req.args.phy];
			if (!phy_data)
				return libubus.STATUS_INVALID_ARGUMENT;
			let ret = false;
			for (let ifname in phy_data.data) {
				let iface = wpas.interfaces[ifname];
				if (!iface)
					continue;
				wpas.printf(`trigger reconnect`);
				ret = iface.reconnect(req.args.radio);
			}
			if (!ret)
				return libubus.STATUS_UNKNOWN_ERROR;
			return 0;
		}
	}
};

wpas.data.ubus = ubus;
wpas.data.obj = ubus.publish("wpa_supplicant", main_obj);
wpas.udebug_set("wpa_supplicant", wpas.data.ubus);

function iface_event(type, name, data) {
	let ubus = wpas.data.ubus;

	data ??= {};
	data.name = name;
	wpas.data.obj.notify(`iface.${type}`, data, null, null, null, -1);
	ubus.call("service", "event", { type: `wpa_supplicant.${name}.${type}`, data: {} });
}

function iface_hostapd_notify(phy, radio, ifname, iface, state, vap_type)
{
	let ubus = wpas.data.ubus;
	let status = iface.status(radio);
	let msg = { phy: phy, radio: radio, mon_ifaces: mon_ifaces[radio]};

	msg.wpa_state = state;
	msg.vap_type = vap_type;

	switch (state) {
	case "DISCONNECTED":
	case "AUTHENTICATING":
	case "SCANNING":
		msg.up = false;
		break;
	case "INTERFACE_DISABLED":
	case "INACTIVE":
		msg.up = true;
		break;
	case "COMPLETED":
		msg.up = true;
		if (status.frequency != null)
			msg.frequency = status.frequency;
		if (status.chan_width != null)
			msg.chan_width = status.chan_width;
		if (status.sec_chan_offset != null)
			msg.sec_chan_offset = status.sec_chan_offset;
		if (status.center_freq1 != null)
			msg.center_freq1 = status.center_freq1;
		if (status.center_freq2 != null)
			msg.center_freq2 = status.center_freq2;
		if (status.punct_bitmap != null)
			msg.punct_bitmap = status.punct_bitmap;
		if (status.is_dfs != null)
			msg.is_dfs = status.is_dfs;
		break;
	default:
		return;
	}
	
	wpas.printf(`apsta_state message passed ${msg}`);
	ubus.call("hostapd", "apsta_state", msg);
}

function iface_channel_switch(phy, radio, ifname, iface, info, vap_type)
{
	let msg = {
		phy: phy,
		radio: radio,
		up: true,
		frequency: info.frequency,
		chan_width: info.chan_width,
		sec_chan_offset: info.sec_chan_offset,
		center_freq1: info.center_freq1,
		center_freq2: info.center_freq2,
		csa: true,
		csa_count: info.csa_count ? info.csa_count - 1 : 0,
		punct_bitmap: info.punct_bitmap,
		is_dfs: info.is_dfs,
		wpa_state: info.wpa_state,
	};
	msg.vap_type = vap_type;
	wpas.printf(`channel switch ${msg}`);

	ubus.call("hostapd", "apsta_state", msg);
}

function iface_pre_connect_hostapd_notify(phy, radio, ifname, iface, state, info, vap_type)
{
	let ubus = wpas.data.ubus;
	let msg = {
		phy: phy,
		radio: radio,
		up: true,
		frequency: info.frequency,
		chan_width: info.chan_width,
		sec_chan_offset: info.sec_chan_offset,
		center_freq1: info.center_freq1,
		center_freq2: info.center_freq2,
		csa: true,
		csa_count: 10,
		punct_bitmap: info.punct_bitmap,
		mon_ifaces: "",
		is_dfs: info.is_dfs,
		wpa_state: state,
	 };

	msg.vap_type = vap_type;
	wpas.printf(`apsta_state:iface_pre_connect_hostapd_notify message passed ${msg}`);
	ubus.defer("hostapd", "apsta_state", msg);
}

return {
	shutdown: function() {
		for (let phy in wpas.data.config)
			set_config(phy, []);
		wpas.ubus.disconnect();
	},
	iface_add: function(name, obj) {
		iface_event("add", name);
	},
	iface_remove: function(name, obj) {
		iface_event("remove", name);
	},
	state: function(ifname, radio, iface, state, vap_type) {
		let phy = wpas.data.iface_phy[ifname];
		if (!phy) {
			wpas.printf(`no PHY for ifname ${ifname}`);
			return;
		}

                let phy_data = wpas.data.config[phy];
                if (!phy_data)
                        return;

		if (!radio)
			iface_hostapd_notify(phy_data.name, -1, ifname, iface, state, vap_type);

		let radio_id = 0;
		while (radio) {
			if (radio & 1) {
				iface_hostapd_notify(phy_data.name, radio_id, ifname, iface, state, vap_type);
			}
			radio >>= 1;
			radio_id++;
		}

		if (state != "COMPLETED")
			return;

		let iface_data = phy_data.data[ifname];
		if (!iface_data)
			return;

		let wdev_config = iface_data.config;
		if (!wdev_config || wdev_config.mode != "mesh")
			return;

		wdev_set_mesh_params(ifname, wdev_config);
	},
	event: function(ifname, radio, iface, ev, info, vap_type) {
		let phy = wpas.data.iface_phy[ifname];
		if (!phy) {
			wpas.printf(`no PHY for ifname ${ifname}`);
			return;
		}
		let phy_data = wpas.data.config[phy];
		if (!phy_data)
			return;

		if (ev == "CH_SWITCH_STARTED" || ev == "LINK_CH_SWITCH_STARTED")
			iface_channel_switch(phy_data.name, radio, ifname, iface, info, vap_type);
	},
	pre_connect_state: function(ifname, radio, iface, state, info, vap_type) {
		let phy = wpas.data.iface_phy[ifname];
		if (!phy) {
			wpas.printf(`no PHY for ifname ${ifname}`);
			return;
		}
		if (state != "PRE_CONNECT")
			return;

		let phy_data = wpas.data.config[phy];
		if (!phy_data)
			return;

		iface_pre_connect_hostapd_notify(phy_data.name, radio, ifname, iface, state, info, vap_type);
	}
};
