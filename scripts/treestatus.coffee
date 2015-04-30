#   Asks treestatus.mozilla.org about trees
#
# Commands:
#   hubot treestatus <treename> - Displays treestatus and message for specified treename


module.exports = (robot) ->
    robot.respond /treestatus (.+)$/i, (msg) ->
        tree = msg.match[1]
        if tree is '' or null
            msg.send "Please specify a tree to get the status of."
            return

        url = 'https://treestatus.mozilla.org/' + msg.match[1] + '?format=json'
        msg.http(url)
            .get() (error, response, body) ->
                if response.statusCode is 404
                    msg.send "I couldn't find a tree with that name. Maybe try another?"
                    return

                if response.statusCode isnt 200
                    msg.send "Request returned status #{response.statusCode} :/"
                    return

                if error
                    msg.send "Oops, had an error fetching treestatus: #{error}"
                    return

                try
                    data = JSON.parse body
                catch e
                    msg.send "Oops! Error type '#{e.type}' fetching treestatus for #{tree}: '#{e.message}'"
                    return

                if data.reason isnt ''
                    result = tree + " has the status " + data.status + " with the reason: " + data.reason
                else
                    result = tree + " has the status " + data.status
                msg.send result

    robot.respond /treestatus$/i, (msg) ->
        msg.send "I don't understand. Please try |#{robot.name}: help| for assistance"
        return
