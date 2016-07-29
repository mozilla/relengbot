# Description
#   SNS parsing for basic notifications
#
# Dependencies:
#   "moment-timezone": "0.2.0"
#
# Configuration:
#   None
#
# Commands:
#   hubot sns [on|off] - Turn SNS notifications to channel on or off
#   hubot sns status - return current status of SNS publication to channel
#
# Notes:
#   This bot is controled by the topic from the ARN set in SNS.
#   The topic == the channel that the bot will try to message when
#   it receives a notification.
#
#   The on/off switch is stored in the robot's brain.
#
# Author:
#   @selenamarie

moment = require 'moment-timezone'

class SNSConfig
    constructor: (@robot) ->
        @cache = []
        @robot.brain.on 'loaded', =>
            if @robot.brain.data.snsconfig
                @cache = @robot.brain.data.snsconfig
    turnOn: ->
        @cache.push "publish"
        @robot.brain.data.snsconfig = @cache
    turnOff: ->
        @cache = []
        @robot.brain.data.snsconfig = @cache
    status: -> "publish" in @cache

module.exports = (robot) ->
    snsConfig = new SNSConfig robot

    robot.respond /sns off$/, (res) ->
        snsConfig.turnOff()
        res.reply "Thanks! Stopping SNS notifications."

    robot.respond /sns on$/, (res) ->
        snsConfig.turnOn()
        res.reply "Thanks! Starting SNS notifications."

    robot.respond /sns status$/, (res) ->
        if snsConfig.status()
            res.reply "SNS notification Publishing is on"
        else
            res.reply "SNS notification publishing is off"

    robot.on "sns:notification", (msg) ->
        """
        Received notification:
            TopicArn:   #{msg.topicArn}
            Topic:      #{msg.topic}
            Message Id: #{msg.messageId}
            Subject:    #{msg.subject}
            Message:    #{msg.message}
        """
        return if not snsConfig.status()

        console.log "msg.message: ", msg.message
        alert = JSON.parse(msg.message)
        # Format:
        # timestamp hostname program message
        # parse the date
        m = new moment(alert.default.received_at)
        robot.messageRoom "##{msg.topic}", "[sns alert] #{m.tz('America/Los_Angeles').format('ddd HH:MM:ss z')} #{alert.default.hostname} #{alert.default.program}: #{alert.default.message}"
