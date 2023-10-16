After('@after-step-demo') do
  PageComplexity.flow.add_page(page)
end

at_exit do
  PageComplexity.flow.generate_report!
end
