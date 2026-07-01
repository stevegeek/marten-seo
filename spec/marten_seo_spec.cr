require "./spec_helper"

describe Marten::SEO do
  it "exposes a version constant" do
    Marten::SEO::VERSION.should eq("0.1.0")
  end

  it "boots the test project (PlainHandler responds)" do
    response = Marten::Spec.client.get("/about")
    response.status.should eq(200)
    response.content.should eq("ok")
  end
end
