# ComfyWings Web API
A web API that allows users to obtain *trip requests* from previously generated query codes.

## Routes

### Root check

`GET /`

Status:

- 200: API server running (happy)

### Query code requested trips

`GET /api/trips/#{QUERY_CODE}` 

Status

- 200: trips request returned (happy)
- 404: trips not found (sad)
- 500: problems obtaining trip information (bad)

### Store trip information

`POST /{origin}/{destination}/{departure_data}/{return_date}/{one_way=false}/{adult_qty}`

Status

- 201: trips stored (happy)
- 404: incorrect trip information (sad)
- 500: problems storing the trips (bad)