module.exports = (robot) ->
  robot.respond /PING$/i, (msg) ->
    role = 'testo'
    if robot.auth.hasRole(msg.envelope.user, 'testo')
      msg.reply "PING"
    else
      msg.reply "NOPE"
   robot.hear /!userid/i, (msg) ->
     msg.reply "Your User ID is: #{msg.message.user.id}"
   robot.hear /!wtf/i, (msg) ->
     msg.send "WTF: #{msg.envelope.user.id}"
