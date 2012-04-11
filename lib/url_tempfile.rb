#from http://mickeyben.com/2010/10/21/handle-url-images-with-dragonfly,-mongomapper-and-rails3.html
class URLTempfile < Tempfile

  def initialize(url, tmpdir = Dir.tmpdir)
    @url = URI.parse(url)
    begin
      super('url', tmpdir)
      Net::HTTP.start(@url.host) do |http|
        resp = http.get(@url.path)
        self.write resp.body
      end
    rescue
      return nil
    end
  end

end