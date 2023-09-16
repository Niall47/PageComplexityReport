# Central class for all test_pack variables
# Usage: artefacts.example
class TestArtefacts
  # attr_accessor :example

  def initialize
    # self.example = []
  end
end

# Initialising TestArtefacts Class object
def artefacts
  @artefacts ||= TestArtefacts.new
end

# Used in after hook when scenario failed
def add_attachments(scenario_name:)
  report_generated_time = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
  attachments_directory = "./failure-reports/#{scenario_name}"

  FileUtils.mkdir_p("#{attachments_directory}/screenshots")
  FileUtils.mkdir_p("#{attachments_directory}/test-data")

  screenshot_path = "#{attachments_directory}/screenshots/#{report_generated_time}.png"
  test_data_path = "#{attachments_directory}/test-data/#{report_generated_time}.json"

  # Test data to be captured in the report of a failed test
  # Example:
  #   { customer_ref: test_data.customer_reference_number,
  #     customer_id: test_data.customer_id,
  #     customer_details: test_data.driver_record.driver_details }
  File.open(test_data_path, 'w') { |f| f.write(JSON.pretty_generate(artefacts.as_json)) }

  page.save_screenshot(screenshot_path, full: true)

  if symbolize(Settings.report_portal.status).eql?(:up)
    ParallelReportPortal.send_file(nil, test_data_path, 'Test Data', ParallelReportPortal.clock, 'application/json')
    ParallelReportPortal.send_file(nil, screenshot_path, 'Screenshot', ParallelReportPortal.clock, 'image/png')
  end
end
