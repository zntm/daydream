/// @desc Handle networking async events in menu

var _type = async_load[? "type"];

// Use new relay system
if (global.relay_manager != undefined)
{
    global.relay_manager.handle_async(_type);
}
