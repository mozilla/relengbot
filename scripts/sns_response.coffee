
moment = require 'moment-timezone'

module.exports = (robot) ->
    robot.hear /sns off/, (res) ->
        robot.brain.set 'sns-publish-irc-messages', false
        res.reply "Thanks! I will stop publishing SNS notifications to IRC."

    robot.hear /sns on/, (res) ->
        robot.brain.set 'sns-publish-irc-messages', true
        res.reply "Thanks! I will start publishing SNS notifications to IRC."

    robot.on "sns:notification", (msg) ->
        """
        Received notification:
            TopicArn:   #{msg.topicArn}
            Topic:      #{msg.topic}
            Message Id: #{msg.messageId}
            Subject:    #{msg.subject}
            Message:    #{msg.message}
        """
        publish_ok = robot.brain.get('sns-publish-irc-messages')
        return if publish_ok isnt true

        alert = JSON.parse(msg.message)
        # Format:
        # timestamp hostname program message
        # parse the date
        m = new moment(alert.default.received_at)
        robot.messageRoom "#releng-hubot-test", "[sns alert] #{m.tz('America/Los_Angeles').format('ddd HH:MM:ss z')} #{alert.default.hostname} #{alert.default.program}: #{alert.default.message}"
