require File.expand_path '../spec_helper.rb', __FILE__

describe "KupiBilet test app" do
  context "Generate link" do
    it "should generate short link" do
      post '/', {longUrl: "https://kupibilet.ru" }
      em_async_continue

      expect(last_response).to be_ok
    end

    it "shouldn't generate short link" do
      post '/', {longUrl: "https://kupibilet.ru" }
      em_async_continue

      expect(last_response).not_to be_ok
    end
  end

  context "Redirect" do
    it "should redirect" do
      url = "https://kupibilet.ru"
      post '/', {longUrl: url }
      em_async_continue

      short_url = JSON.parse(last_response.body)['url']
      get "/#{short_url}'"
      em_async_continue

      expect(last_response.headers['Location']).to eql(url)
    end

    it "shouldn't redirect" do
      get "/kupikupi"
      em_async_continue

      expect(last_response.status).to eql(404)
    end
  end
end