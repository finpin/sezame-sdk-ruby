require 'jsonclient'

# parse json in quirks mode, so that JSON fragments (true, false, simple strings) can be handled
class SezameJSONClient < JSONClient

  def delete(uri, *args, &block)
    request(:delete, uri, argument_to_hash_for_json(args), &block)
  end

  private

  def wrap_json_response(original)
    res = ::HTTP::Message.new_response(JSON.parse(original.content, :quirks_mode => true))
    res.http_header = original.http_header
    res.previous = original
    res
  end
end
