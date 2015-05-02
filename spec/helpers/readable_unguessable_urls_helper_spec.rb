require 'rails_helper'

describe ReadableUnguessableUrlsHelper do
  let(:canonical_host) { 'www.example.com' }
  let(:default_subdomain) { 'www' }
  let(:tld_length) { '1' }
  let(:request) { double(:request,
                         subdomain: default_subdomain,
                         host: canonical_host,
                         port: 80, ssl?: false) }

  before do
    @old_action_mailer_default_url_options = ActionMailer::Base.default_url_options
    ActionMailer::Base.default_url_options = { host: 'www.example.com', port: 3000 }

    ENV['TLD_LENGTH'] = tld_length
    ENV['CANONICAL_HOST'] = canonical_host
    ENV['DEFAULT_SUBDOMAIN'] = default_subdomain

    helper.stub(:request).and_return(request)
  end

  after do
    ActionMailer::Base.default_url_options = @old_action_mailer_default_url_options
  end

  describe "group_url examples" do
    let(:normal_group) { create :group, name: 'normal group', key: 'aaa111' }
    let(:subdomain_group) { create :group, name: 'subdomain group', key: 'bbb222', subdomain: 'subdomain-group' }
    let(:subgroup_with_subdomain) { create :group, parent: subdomain_group, name: 'subgroup with subdomain', key: 'bbb223'}

    context 'loom.io' do
      let(:canonical_host) { 'loom.io' }
      let(:default_subdomain) { nil }
      let(:tld_length) { '1' }

      context "within an email" do
        before { helper.stub(:request).and_return(nil) }

        it "group without subdomain" do
          expect(group_url(normal_group)).to eq 'http://loom.io/g/aaa111/normal-group'
        end

        it "group with subdomain" do
          expect(group_url(subdomain_group)).to eq 'http://subdomain-group.loom.io/'
        end

        it "subgroup with subdomain" do
          expect(group_url(subgroup_with_subdomain)).to eq 'http://subdomain-group.loom.io/g/bbb223/subdomain-group-subgroup-with-subdomain'
        end
      end

      context "via a request" do
        it "group without subdomain" do
          expect(group_url(normal_group)).to eq 'http://loom.io/g/aaa111/normal-group'
        end

        it "group with subdomain" do
          expect(group_url(subdomain_group)).to eq 'http://subdomain-group.loom.io/'
        end

        it "subgroup with subdomain" do
          expect(group_url(subgroup_with_subdomain)).to eq 'http://subdomain-group.loom.io/g/bbb223/subdomain-group-subgroup-with-subdomain'
        end
      end
    end

    context 'www.loomio.org' do
      let(:canonical_host) { 'www.loomio.org' }
      let(:default_subdomain) { 'www' }
      let(:tld_length) { '1' }

      context "within an email" do
        before { helper.stub(:request).and_return(nil) }

        it "group without subdomain" do
          expect(group_url(normal_group)).to eq 'http://www.loomio.org/g/aaa111/normal-group'
        end

        it "group with subdomain" do
          expect(group_url(subdomain_group)).to eq 'http://subdomain-group.loomio.org/'
        end
      end

      context "from a request" do
        it "group without subdomain" do
          expect(group_url(normal_group)).to eq 'http://www.loomio.org/g/aaa111/normal-group'
        end

        it "group with subdomain" do
          expect(group_url(subdomain_group)).to eq 'http://subdomain-group.loomio.org/'
        end
      end
    end

    context "loomio.anotherplace.com" do
      let(:canonical_host) { 'loomio.anotherplace.com' }
      let(:tld_length) { '2' }
      let(:default_subdomain) { nil }

      context "within an email" do
        before { helper.stub(:request).and_return(nil) }

        it "group without subdomain" do
          expect(group_url(normal_group)).to eq 'http://loomio.anotherplace.com/g/aaa111/normal-group'
        end

        it "group with subdomain" do
          expect(group_url(subdomain_group)).to eq 'http://subdomain-group.loomio.anotherplace.com/'
        end
      end

      context "via a request" do
        it "group without subdomain" do
          expect(group_url(normal_group)).to eq 'http://loomio.anotherplace.com/g/aaa111/normal-group'
        end

        it "group with subdomain" do
          expect(group_url(subdomain_group)).to eq 'http://subdomain-group.loomio.anotherplace.com/'
        end
      end
    end
  end

    #describe "for subgroup of group with subdomain" do
      #let(:parent_group) { create(:group, name: 'parent', key: 'parent_key', subdomain: 'parent_subdomain') }
      #let(:group) { create(:group, name: 'subgroup', key: 'key', parent: parent_group) }

      #context "used within an email" do
        #before { helper.stub(:request).and_return(nil) }
        #it{ should == "http://parent_subdomain.example.com:3000/g/key/parent-subgroup" }
      #end

      #context "used on default subdomain" do
        #before { request.stub(:subdomain).and_return('www') }
        #it{ should == "http://parent_subdomain.example.com/g/key/parent-subgroup" }
      #end

      #context "used on custom subdomain" do
        #before { request.stub(:subdomain).and_return('parent_subdomain') }
        #it{ should == "http://parent_subdomain.example.com/g/key/parent-subgroup" }
      #end
    #end
  #end


end

