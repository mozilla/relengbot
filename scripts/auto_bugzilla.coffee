#   Files bugs in bugzilla
#
# Commands:
#   hubot bz [bugid] - Displays treestatus and message for specified treename


bugzilla_url = process.env.HUBOT_BUGZILLA_URL
bugzilla_token = process.env.BUGZILLA_TOKEN

class BugzillaRestAPI
    constructor: (@robot) ->
        @base_url = bugzilla_url
        # XXX put credentials in here
    getBug: (msg, bugid) ->
        url = @base_url + '/rest/bug/' + bugid
        msg.http(url)
            .get() (error, response, body) ->
                if response.statusCode is 404
                    msg.send "I couldn't find bug #{bugid}"
                try
                    bugdata = JSON.parse body
                    filtered = bugdata.bugs.filter (n) -> n.id == parseInt(bugid)
                    for b in filtered
                        msg.reply "[#{bugid}] #{b.product} #{b.component} #{b.status} '#{b.summary}' http://bugzil.la/#{bugid}"
                catch e
                    msg.send "Oops! Error type '#{e.type}' fetching bugzilla data for #{bugid}: '#{e.message}'"
    createBug: (msg, product, component, depends_on, summary) ->
        data = JSON.stringify({
            product: product
            component: component
            version: "unspecified"
            summary: summary
            depends_on: depends_on
        })
        console.log data
        url = @base_url + "/rest/bug?api_key=#{bugzilla_token}"
        msg.http(url)
            .post(data) (err, res, body) ->
                if res.statusCode is not 200
                    msg.send "Oops! status code was not 200."
                msg.reply body
    createDiagBug: (msg, system_name, depends_on) ->
        summary = "Please run diagnostics on #{system_name}"
        this.createBug(msg, 'Infrastructure & Operations', 'RelOps', depends_on, summary)

module.exports = (robot) ->

    bzrest = new BugzillaRestAPI robot

    robot.respond /bz (\d+)$/i, (msg) ->
        bugid = msg.match[1]
        if bugid is '' or null
            msg.send "Please specify a bug."
            return
        bzrest.getBug(msg, bugid)

    robot.respond /bz create ([A-Za-z0-9_-]+) (\d+)/, (msg) ->
        system_name = msg.match[1]
        bugid = msg.match[2]

        bzrest.createDiagBug(msg, system_name, bugid)
