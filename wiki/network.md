
##shared

- [network.Connect](nil)(ip, port, retries)
- [network.Disconnect](nil)(reason)
- [network.GetAvailableServers](nil)()
- [network.GetHostname](nil)()
- [network.HandlePacket](nil)(str, peer, type)
- [network.IDToString](nil)(id)
- [network.IsConnected](nil)()
- [network.IsStarted](nil)()
- [network.JoinIRCServer](nil)()
- [network.OnIRCMessage](nil)(irc_client, message, nick, ip)
- [network.PrintOnServer](nil)(str)
- [network.QueryAvailableServers](nil)()
- [network.SendPacketToHost](nil)(str, flags, channel)
- [network.SetHostName](nil)(str)
- [network.StringToID](nil)(str)
- [network.UpdateStatistics](nil)()