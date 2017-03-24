module.exports = (robot) ->
  robot.hear /!userinfo/i, (msg) ->
     for k,v of msg.message.user
        msg.send "Key : #{k} Value : #{v}"


