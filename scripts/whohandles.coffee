# Description:
#   Add 'who handles' capability to the bot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot say <who> when asked about <topic> - Remember <who> handles <topic>
#   hubot who handles <topic> - Return the name or channel to go to for help
#   hubot what do you know - Return the list of everything you know
#   hubot forget topic <topic> - Remove exact match on topic
#   hubot forget topics by regex <regex> - Remove any topics that match the supplied regex
#   hubot forget handler <who> - Remove all references to handler <who>
#
# Author:
#   selenamarie

class WhoHandles
    constructor: (@robot) ->
        @cache = []
        @robot.brain.on 'loaded', =>
            if @robot.brain.data.whohandles
                @cache = @robot.brain.data.whohandles
    add: (topic, who) ->
        task = {key: topic, handler: who}
        @cache.push task
        @robot.brain.data.whohandles = @cache
    all: -> @cache
    deleteByWho: (who) ->
        @cache = @cache.filter (n) -> n.handler != who
        @robot.brain.data.whohandles = @cache
    deleteByTopic: (topic) ->
        @cache = @cache.filter (n) -> n.key != topic
        @robot.brain.data.whohandles = @cache
    deleteByTopicRegex: (topic) ->
        regex = ///#{topic}///i
        @cache = @cache.filter (n) -> ! n.key.match regex
        @robot.brain.data.whohandles = @cache
    deleteAll: ->
        @cache = []
        @robot.brain.data.whohandles = @cache
    findTopic: (topic) ->
        # do rough pattern match
        regex = ///#{topic}///i
        @cache.filter (n) -> n.key.match regex

module.exports = (robot) ->
    whoHandles = new WhoHandles robot

    robot.respond /say (.+?) when asked about (.+?)$/i, (msg) ->
        who = msg.match[1]
        topic = msg.match[2]
        whoHandles.add(topic, who)
        msg.send "I'll say #{who} if someone asks about #{topic}"

    robot.respond /who handles (.+?)/i, (msg) ->
        topic = msg.match[1]
        for known_topic in whoHandles.findTopic(topic)
            msg.send "#{known_topic.handler} handles #{known_topic.key}"

    robot.respond /what do you know/i, (msg) ->
        topics = whoHandles.all()
        msg.send "Nothing!" if topics.length == 0
        for topic in topics
            msg.send "#{topic.handler} handles #{topic.key}"

    # probably should set up permissions and a backing storage
    # so that we can have DR in the event someone does this by mistake
    robot.respond /forget handler (.+?)$/i, (msg) ->
        who = msg.match[1]
        whoHandles.deleteByWho(who)
        msg.send "I removed what I knew about #{who}"

    robot.respond /forget topics by regex (.+?)$/i, (msg) ->
        topics = msg.match[1]
        whoHandles.deleteByTopicRegex(topics)
        msg.send "I removed what I knew about #{topics}"

    robot.respond /forget topic (.+?)$/i, (msg) ->
        topic = msg.match[1]
        whoHandles.deleteByTopic(topic)
        msg.send "I removed what I knew about #{topic}"
