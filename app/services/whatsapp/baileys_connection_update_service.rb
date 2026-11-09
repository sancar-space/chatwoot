class Whatsapp::BaileysConnectionUpdateService
  def initialize(channel:, event:, data:)
    @channel = channel
    @event = event
    @data = data.with_indifferent_access
  end

  def perform
    case @event
    when 'qr.updated'
      update_qr
    when 'connection.update'
      update_connection_status
    end
  end

  private

  def update_qr
    @channel.update!(provider_config: @channel.provider_config.merge(
      'connection_status' => 'qr_pending',
      'qr_data_url' => @data[:qr]
    ))
    Rails.logger.info "[BAILEYS] QR code updated for channel #{@channel.id}"
  end

  def update_connection_status
    status = @data[:status].to_s
    base_config = @channel.provider_config.reject { |k, _| k == 'qr_data_url' }

    updates = { 'connection_status' => status }
    updates['connected_phone_number'] = @data[:phoneNumber] if @data[:phoneNumber].present?

    @channel.update!(provider_config: base_config.merge(updates))
    Rails.logger.info "[BAILEYS] Connection status '#{status}' for channel #{@channel.id}"
  end
end
