module.exports = (robot) ->
  robot.respond /PING$/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'testo')
      msg.reply "PING"
    else
      msg.reply "No PING for you!"
   robot.hear /!userid/i, (msg) ->
     msg.reply "Your User ID is: #{msg.message.user.id}"
   robot.hear /!wtf/i, (msg) ->
     msg.send "WTF: #{msg.envelope.user.id}"
