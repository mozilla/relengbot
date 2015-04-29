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
        robot.messageRoom "#releng-hubot-test", "#{msg.subject} #{msg.message}"
