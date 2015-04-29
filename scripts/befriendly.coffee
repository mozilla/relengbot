module.exports = (robot) ->
    robot.hear /h.* relengbot/i, (msg) ->
        msg.send "I hope I can be helpful. :]"
