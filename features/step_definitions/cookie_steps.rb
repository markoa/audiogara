# This is from https://gist.github.com/484787
# via http://stackoverflow.com/questions/4176958/cookies-within-a-cucumber-test-using-capybara

Then /^show me the cookies!$/ do
  driver = Capybara.current_session.driver
  case driver
  when Capybara::Driver::Selenium
    announce_selenium_cookies(Capybara.current_session.driver.browser)
  when Capybara::Driver::RackTest
    announce_rack_test_cookies(get_rack_test_cookie_jar)
  else 
    raise "unsupported driver, use rack::test or selenium/webdriver"
  end
end

Given /^I close my browser \(clearing the Medify session\)$/ do
  delete_cookie session_cookie_name
end

module CookieStepHelper
  def session_cookie_name
    Rails.application.config.session_options[:key] #for rails 3, courtesy of https://github.com/ilpoldo
    #else just hard code it as follows
    #'_appname_session' #or check in browser for what your app is using
  end

  def delete_cookie(cookie_name)
    driver = Capybara.current_session.driver
    case driver
    when Capybara::Driver::Selenium
      browser = Capybara.current_session.driver.browser
      announce_selenium_cookies(browser) if @announce
      browser.manage.delete_cookie(cookie_name)
      announce "Deleted cookie: #{cookie_name}" if @announce
      announce_selenium_cookies(browser) if @announce
    when Capybara::Driver::RackTest
      announce_rack_test_cookies(get_rack_test_cookie_jar) if @announce
      delete_rack_test_cookie(get_rack_test_cookie_jar, cookie_name)
      announce "Deleted cookie: #{cookie_name}" if @announce
      announce_rack_test_cookies(get_rack_test_cookie_jar) if @announce
    else 
      raise "unsupported driver, use rack::test or selenium/webdriver"
    end
  end

  def announce_rack_test_cookies(cookie_jar)
    announce "Current cookies: #{cookie_jar.instance_variable_get(:@cookies).map(&:inspect).join("\n")}"
  end
  
  def announce_selenium_cookies(browser)
    announce "Current cookies: #{browser.manage.all_cookies.map(&:inspect).join("\n")}"
  end
  
  def get_rack_test_cookie_jar
    rack_test_driver = Capybara.current_session.driver
    cookie_jar = rack_test_driver.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
  end
  
  def delete_rack_test_cookie(cookie_jar, cookie_name)
    cookie_jar.instance_variable_get(:@cookies).reject! do |existing_cookie|
      existing_cookie.name.downcase == cookie_name
    end
  end
end
World(CookieStepHelper)
Before('@announce') do
  @announce = true
end
