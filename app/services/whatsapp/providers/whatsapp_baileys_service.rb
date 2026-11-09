class Whatsapp::Providers::WhatsappBaileysService < Whatsapp::Providers::BaseService
  TIMEOUT = 10

  def validate_provider_config?
    true
  end

  def sync_templates; end

  def sync_template; end

  def api_headers
    { 'x-api-key' => current_api_key }
  end

  def media_url(_media_id)
    nil
  end

  def send_message(recipient_id, message)
    if message.attachments.any?
      send_media_messages(recipient_id, message)
    else
      send_text_message(recipient_id, message)
    end
  end

  def send_template(_recipient_id, _template_info, _message)
    Rails.logger.info '[BAILEYS] send_template not supported'
    nil
  end

  def setup_channel_provider
    response = HTTParty.post(
      "#{provider_url}/instances",
      headers: api_request_headers,
      body: { instanceId: instance_id, webhookUrl: build_webhook_url }.to_json,
      timeout: TIMEOUT
    )
    raise "[BAILEYS] Setup failed: #{response.body}" unless response.success?

    response
  rescue HTTParty::Error, Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error "[BAILEYS] setup_channel_provider error: #{e.message}"
    raise
  end

  def disconnect_channel_provider
    HTTParty.delete(
      "#{provider_url}/instances/#{instance_id}",
      headers: api_request_headers,
      timeout: TIMEOUT
    )
  rescue StandardError => e
    Rails.logger.error "[BAILEYS] disconnect_channel_provider error: #{e.message}"
  end

  private

  def instance_id
    whatsapp_channel.phone_number.gsub(/\D/, '')
  end

  def provider_url
    whatsapp_channel.provider_config&.dig('provider_url').presence ||
      ENV.fetch('BAILEYS_PROVIDER_DEFAULT_URL', 'http://baileys-api:3025')
  end

  def current_api_key
    whatsapp_channel.provider_config&.dig('api_key').presence ||
      ENV.fetch('BAILEYS_PROVIDER_DEFAULT_API_KEY', '')
  end

  def api_request_headers
    { 'x-api-key' => current_api_key, 'Content-Type' => 'application/json' }
  end

  def build_webhook_url
    base = ENV.fetch('INTERNAL_HOST_URL', ENV.fetch('FRONTEND_URL', 'http://rails:3000'))
    "#{base}/webhooks/whatsapp/baileys/#{instance_id}"
  end

  def send_text_message(recipient_id, message)
    return nil if message.content.blank?

    response = HTTParty.post(
      "#{provider_url}/instances/#{instance_id}/send-text",
      headers: api_request_headers,
      body: { jid: normalize_jid(recipient_id), message: message.content.to_s }.to_json,
      timeout: TIMEOUT
    )
    return nil unless response.success?

    "#{instance_id}_#{message.id}"
  rescue StandardError => e
    Rails.logger.error "[BAILEYS] send_text_message error: #{e.message}"
    nil
  end

  def send_media_messages(recipient_id, message)
    message.attachments.each do |attachment|
      send_single_media(recipient_id, message, attachment)
    end
  end

  def send_single_media(recipient_id, message, attachment)
    HTTParty.post(
      "#{provider_url}/instances/#{instance_id}/send-media",
      headers: api_request_headers,
      body: {
        jid: normalize_jid(recipient_id),
        mediaUrl: attachment.download_url,
        mediaType: media_type_for(attachment),
        caption: message.content.presence,
        filename: attachment.file&.filename.to_s.presence
      }.compact.to_json,
      timeout: TIMEOUT
    )
  rescue StandardError => e
    Rails.logger.error "[BAILEYS] send_single_media error: #{e.message}"
  end

  def normalize_jid(phone)
    return phone.to_s if phone.to_s.include?('@')

    "#{phone.to_s.gsub(/\D/, '')}@s.whatsapp.net"
  end

  def media_type_for(attachment)
    case attachment.file_type.to_s
    when 'image' then 'image'
    when 'audio' then 'audio'
    when 'video' then 'video'
    else 'document'
    end
  end
end
