module Mirage
  module Web
    class FileResponse
      def initialize response
        @response = response
      end

      def save_as path
        @response.save_as(path)
      end
    end

    def http_get url, params={}
      uri = URI.parse(url)
      if params[:body]
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          request = Net::HTTP::Get.new(uri.path)
          request.body=params[:body]
          http.request(request)
        end

        def response.code
          @code.to_i
        end

      else
        response = using_mechanize do |browser|
          browser.get(url, params)
        end
      end

      response
    end

    def http_post url, params={}
      using_mechanize do |browser|
        browser.post(url, params)
      end
    end

    private
    def using_mechanize
      begin
        browser = Mechanize.new
        browser.keep_alive = false
        response = yield browser

        def response.code
          @code.to_i
        end
      rescue Exception => e
        response = e

        def response.code
          self.response_code.to_i
        end

        def response.body
          ""
        end
      end
      response
    end
  end
end
