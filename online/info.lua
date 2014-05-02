-- if we don't know the difference between server and client, don't load
return
{
	load = CLIENT ~= nil or SERVER ~= nil,
	event = "OnlineStarted",
}