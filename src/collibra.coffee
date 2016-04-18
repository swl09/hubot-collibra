collibra_rest_uri = 'rest/1.0/search'

if process.env.HUBOT_COLLIBRA_KW?
  my_name = process.env.HUBOT_COLLIBRA_KW
else
  my_name = "collibra"

  
if process.env.HUBOT_COLLIBRA_LIMIT?
  limit = process.env.HUBOT_COLLIBRA_LIMIT
else
  limit = 10 

name_regex = new RegExp("^#{my_name}:\\s*([^\\n]+)", "i")
  
module.exports = (robot) ->

  # Add a task
  robot.respond /ping/, (msg) ->
    msg.reply "PONG!"

  # The main one
  #robot.respond /^tad:\\s*([^\\n]+)/i, (msg) ->
  robot.respond /tad:\s*(.+)$/, (msg) ->
    msg.reply "HI!"
    search = msg.match[1]
    #search = "ACRD"

    if not process.env.HUBOT_COLLIBRA_URL? or not process.env.HUBOT_COLLIBRA_USER? or not process.env.HUBOT_COLLIBRA_PASS?
      msg.reply "Must specify HUBOT_COLLIBRA_URL, HUBOT_COLLIBRA_USER and HUBOT_COLLIBRA_PASS"
    else 
      msg.reply "Searching for " + search
  
      # Set up the JSON for the Collibra REST API /search call - this unfortunately will likely need to be different for each
      # collibra instance, since the guids will be different
      stringParams = """
{
  "filter": {
    "category": [
      "TE",
      "VC",
      "CO",
      "SS",
      "UR",
      "GR"
    ],
    "includeMeta": false,
    "type": {
      "asset": [
        "00000000-0000-0000-0000-000000011001"
      ],
      "domain": []
    },
    "community": [],
    "vocabulary": [],
    "status": []
  },
  "fields": [
    "name",
    "comment",
    "00000000-0000-0000-0000-000000003114",
    "00000000-0000-0000-0000-000000000202"
  ],
  "order": {
    "by": "score",
    "sort": "desc"
  },
  "offset": 0,
  "limit": #{limit},
  "highlight": true,
  "relativeUrl": true,
  "query": "#{search}"
}
"""

      # Set up the Authorization info for passing to the Collibra API
      authdata = new Buffer(process.env.HUBOT_COLLIBRA_USER+':'+process.env.HUBOT_COLLIBRA_PASS).toString('base64')


      msg.http(process.env.HUBOT_COLLIBRA_URL + collibra_rest_uri)
        .headers("Content-Length": stringParams.length, "Content-type": "application/json", "Accept": "application/json", "Authorization": 'Basic ' + authdata)
        .post(stringParams) (err, res, body) ->
          response = JSON.parse(body) 
  
          msg.reply "Search Result Count: " + response.total + ", showing the first #{limit}\n"
  
          outstr = ""
          for k,v of response.results
            term_text = v.name.val.replace /\<\/*B\>/g, ''
            outstr = outstr + "*" + term_text + "*\n(" + process.env.HUBOT_COLLIBRA_URL +  v.name.pageUrl + ")\n"
  
            for x,y of v.attributes
              label_text = y.type.replace /\<\/*B\>/g, '_'
              proc_text = y.val.replace /\<\/*B\>/g, '_'
              if label_text is "Definition"
                outstr = outstr + " - " + label_text + ": " + proc_text + "\n"
  
            outstr = outstr + "\n"
     
          msg.reply outstr
                
