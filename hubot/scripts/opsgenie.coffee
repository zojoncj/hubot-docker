# Description:
#    Interaction with the OpsGenie API to list and acknowledge alerts, and to manipulate the on-call schedule.
#
# Configuration:
#   HUBOT_OPSGENIE_CUSTOMER_KEY
#
# Commands:
#   hubot genie status - Lists open alerts
#   hubot genie ack id - Acknoledge a specific alert. The ids are listed in the status output.
#   hubot genie close id - Close a specific alert.
#
# Author:
#   roidrage
#   zojoncj
module.exports = (robot) ->
  baseUrl = "https://api.opsgenie.com/v1/json/"
  customerKey = process.env.HUBOT_OPSGENIE_CUSTOMER_KEY
  
  robot.respond /genie who is on call(.*)?/, (msg) ->
    unless robot.auth.hasRole(msg.envelope.user, 'paging')
      return
    msg.http("#{baseUrl}/schedule/whoIsOnCall").
        query({customerKey: customerKey}).
        get() (err, res, body) ->
      response = JSON.parse body
      oncalls = response.oncalls
      for oncall in oncalls
        msg.send "#{oncall.name} - #{oncall.participants[0].name}"
    

  robot.respond /genie status\??$/i, (msg) ->
    unless robot.auth.hasRole(msg.envelope.user, 'paging')
      return
    createdSince = new Date()
    createdSince.setTime(createdSince.getTime() - 48 * 60 * 60 * 1000)
    createdSince = parseInt(createdSince.getTime() * 1000 * 1000)
    msg.http("#{baseUrl}/alert").
        query({customerKey: customerKey, status: 'open', createdAfter: createdSince}).
        get() (err, res, body) ->
      response = JSON.parse body
      alerts = response.alerts
      if alerts.length == 0
        msg.send "No open alerts."
      else
        unacked = (alert for alert in alerts when not alert.acknowledged)
        acked = (alert for alert in alerts when alert.acknowledged)
        msg.send "Found #{acked.length} acked and #{unacked.length} unacked alerts"
        for alert in alerts
          do (alert) ->
            msg.http("#{baseUrl}/alert").
                query({customerKey: customerKey, id: alert.id}).
                get() (err, res, body) ->
              alert = JSON.parse body
              msg.send "#{alert.tinyId}:  #{alert.message} (source: #{alert.source}, #{if alert.acknowledged then "acked by #{alert.owner}" else "unacked"})"

  
  robot.respond /genie ack ([0-9]+)$/i, (msg) ->
    unless robot.auth.hasRole(msg.envelope.user, 'paging')
      return
    tinyId = msg.match[1]
    msg.http("#{baseUrl}/alert").
        query({customerKey: customerKey, tinyId: tinyId}).
        get() (err, res, body) ->
      alert = JSON.parse body
      if alert.error
        msg.send "I had problems finding an alert with the id #{tinyId}"
      else
        body = JSON.stringify {
          customerKey: customerKey,
          alertId: alert.id,
          user: opsGenieUser(msg)
        }
        msg.http("#{baseUrl}/alert/acknowledge").post(body) (err, res, body) ->
          msg.send "Acknowledged: #{alert.message}"

  robot.respond /genie close ([0-9]+)$/i, (msg) ->
    unless robot.auth.hasRole(msg.envelope.user, 'paging')
      return
    tinyId = msg.match[1]
    msg.http("#{baseUrl}/alert").
        query({customerKey: customerKey, tinyId: tinyId}).
        get() (err, res, body) ->
      alert = JSON.parse body
      if alert.error
        msg.send "I had problems finding an alert with the id #{tinyId}"
      else
        body = JSON.stringify {
          customerKey: customerKey,
          alertId: alert.id,
          user: opsGenieUser(msg)
        }
        msg.http("#{baseUrl}/alert/close").post(body) (err, res, body) ->
          msg.send "Closed: #{alert.message}"

  opsGenieUser = (msg) ->
     msg.message.user.email_address
