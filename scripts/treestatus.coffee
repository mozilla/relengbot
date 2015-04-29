module.exports = (robot) ->
    robot.respond /treestatus (.+)/i, (msg) ->
        tree = msg.match[1]
        url = 'https://treestatus.mozilla.org/' + msg.match[1] + '?format=json'
        msg.http(url)
            .get() (error, response, body) ->
                data = JSON.parse body
                result = tree + " has the status " + data.status + " with the reason: " + data.reason if data.reason isnt ''
                result = tree + " has the status " + data.status if data.reason is ''
                msg.send result
