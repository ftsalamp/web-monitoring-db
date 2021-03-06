class Api::V0::ImportsController < Api::V0::ApiController
  def show
    @import ||= Import.find(params[:id])
    status_code = @import.complete? ? 200 : 202
    render status: status_code, json: {
      data: @import
    }
  end

  def create
    update_behavior = params[:update] || :skip
    unless Import.update_behaviors.key?(update_behavior)
      raise Api::InputError, "'#{update_behavior}' is not a valid update behavior. Use one of: #{Import.update_behaviors.join(', ')}"
    end

    @import = Import.create_with_data({
      user: current_user,
      update_behavior: update_behavior,
      create_pages: boolean_param(:create_pages, default: true)
    }, request.body)
    ImportVersionsJob.perform_later(@import)
    show
  end
end
