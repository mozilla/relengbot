
moment = require 'moment-timezone'

module.exports = (robot) ->
    robot.on "sns:notification", (msg) ->
        """
        Received notification:
            TopicArn:   #{msg.topicArn}
            Topic:      #{msg.topic}
            Message Id: #{msg.messageId}
            Subject:    #{msg.subject}
            Message:    #{msg.message}
        """
        alert = JSON.parse(msg.message)
        # Format:
        # timestamp hostname program message
        # parse the date
        m = new moment(alert.default.received_at)
        robot.messageRoom "#releng-hubot-test", "[sns alert] #{m.tz('America/Los_Angeles').format('ddd HH:MM:ss z')} #{alert.default.hostname} #{alert.default.program}: #{alert.default.message}"
