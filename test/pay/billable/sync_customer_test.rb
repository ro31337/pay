require "test_helper"

class Pay::Billable::SyncCustomer::Test < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "email sync only on updating customer email" do
    assert_no_enqueued_jobs do
      User.create(email: "test@example.com")
    end

    assert_enqueued_with(job: Pay::CustomerSyncJob, args: [users(:stripe).payment_processor.id]) do
      users(:stripe).update(email: "test@test.com")
    end
  end

  test "email sync should be ignored for billable that delegates email" do
    assert_no_enqueued_jobs do
      Team.create(name: "Team 1")
    end
  end

  test "queues multiple jobs if a user has multiple payment processors" do
    user = users(:multiple)
    assert_enqueued_jobs 2 do
      user.update(email: "test@test.com")
    end
  end
end
