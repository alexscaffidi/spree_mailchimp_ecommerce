require "spec_helper"

describe Spree::User, type: :model do
  subject { build(:user_with_addresses) }

  describe "mailchimp" do
    it "schedules mailchimp notification on user create" do
      subject.save!

      expect(SpreeMailchimpEcommerce::CreateUserJob).to have_been_enqueued.with(subject.mailchimp_user)
    end

    it "schedules mailchimp notification on user update" do
      subject.save!
      subject.update(email: "new@mail.com")

      expect(SpreeMailchimpEcommerce::UpdateUserJob).to have_been_enqueued.with(subject.mailchimp_user)
    end
  end

  describe ".mailchimp_user" do
    it "returns valid schema" do
      expect(subject.mailchimp_user).to match_json_schema("user")
    end

    it "doesn't send unnecessary requests to db" do
      subject.save!

      expect { subject.mailchimp_user }.not_to exceed_query_limit(1)
    end
  end
end
