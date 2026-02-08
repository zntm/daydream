/// @desc Async Networking Event - Handle incoming network traffic

var _type = async_load[? "type"];

// Use new relay system
if (global.relay_manager != undefined)
{
    global.relay_manager.handle_async(_type);
}
