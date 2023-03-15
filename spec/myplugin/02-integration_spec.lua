local helpers = require "spec.helpers"
local httpc = require("resty.http").new()

local PLUGIN_NAME = "myplugin"


  local strategy = "postgres"
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()


    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { PLUGIN_NAME })

      local service1 = bp.services:insert({
        host = "mockserver",
        port = 1080,
        protocol = "http"
      })

      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
        service = {id = service1.id},
      })
      -- add the plugin to test to the route we created
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {},
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- -- use the custom test template to create a local mock server
        -- nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
        -- write & load declarative config, only if 'strategy=off'
        declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    describe("request", function()
      it("gets a 'hello-world' header", function()
        local r, err = httpc:request_uri("http://localhost:9000/json", {
          headers = {
            host = "test1.com"
          }
        })

        assert.equal(200, r.status)
      end)
    end)

    describe("response", function()
      it("gets a 'bye-world' header", function()
        local r, err = httpc:request_uri("http://localhost:9000/html", {
          headers = {
            host = "test1.com"
          }
        })

        assert.equal(r.status, 200)
        assert.equal("this is on the response", r.headers["bye-world"])
      end)
    end)

  end)


