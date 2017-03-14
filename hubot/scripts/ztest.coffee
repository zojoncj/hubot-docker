module.exports = (robot) ->
  robot.respond /PING$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'testo')
      msg.reply "PING"
    else
      msg.reply "NOPE"
   robot.hear /!userinfo/i, (msg) ->
     for k,v of msg.message.user
        msg.send "Key : #{k} Value : #{v}"


