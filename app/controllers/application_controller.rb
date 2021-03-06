class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions
  include TokenValidatable

  check_authorization

  # User.current is required to be set for OffersController.before_filter
  before_action :set_locale, :current_user
  helper_method :current_user

  def is_admin_app
    current_user.try(:staff?) && app_name == ADMIN_APP
  end

  def is_stockit_request
    app_name == STOCKIT_APP
  end

  def is_stock_app
    app_name == STOCK_APP
  end

  def is_browse_app
    app_name == BROWSE_APP
  end

  protected

  def app_name
    request.headers['X-GOODCITY-APP-NAME'] || meta_info["appName"]
  end

  def meta_info
    meta = request.headers["X-META"].try(:split, "|")
    meta ? Hash[*meta.flat_map{|a| a.split(":")}] : {}
  end

  def app_version
    request.headers['X-GOODCITY-APP-VERSION']
  end

  def app_sha
    request.headers['X-GOODCITY-APP-SHA']
  end

  private

  def set_locale
    I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales) || "en"
  end

  def current_user
    @current_user ||= begin
      user = nil
      User.current_user = nil
      if token.valid?
        user_id = token.data[0]["user_id"]
        user = User.find_by_id(user_id) if user_id.present?
        if user
          user.instance_variable_set(:@treat_user_as_donor, true) unless STAFF_APPS.include?(app_name)
          User.current_user = user
        end
      end
      user
    end
  end
end
