class Whatsapp::IncomingMessageBaileysService
  attr_reader :inbox, :params

  def initialize(inbox:, params:)
    @inbox = inbox
    @params = params.with_indifferent_access
  end

  def perform
    data = @params[:data]
    return if data.blank?
    return if data[:isGroup]

    @message_source_id = data.dig(:key, :id).to_s
    @phone_number = data[:phoneNumber].to_s.gsub(/\D/, '')
    return if @phone_number.blank?
    return if Message.where(source_id: @message_source_id, inbox_id: @inbox.id).any?

    @contact_name = data[:pushName].to_s.presence || @phone_number
    @content = data[:content].to_s

    build_contact
    build_conversation
    create_message(data)
  end

  private

  def build_contact
    result = ContactInboxWithContactBuilder.new(
      source_id: @phone_number,
      inbox: @inbox,
      contact_attributes: {
        name: @contact_name,
        phone_number: "+#{@phone_number}"
      }
    ).perform
    @contact_inbox = result
    @contact = result.contact
  end

  def build_conversation
    @conversation = @contact_inbox.conversations
                                  .where(status: %w[open pending snoozed])
                                  .last
    @conversation ||= Conversation.create!(
      account_id: @inbox.account_id,
      inbox_id: @inbox.id,
      contact_id: @contact.id,
      contact_inbox_id: @contact_inbox.id
    )
  end

  def create_message(data)
    content = @content.presence || "[#{data[:messageType]}]"

    @conversation.messages.create!(
      account_id: @inbox.account_id,
      inbox_id: @inbox.id,
      message_type: :incoming,
      author: @contact,
      content: content,
      sender: @contact,
      source_id: @message_source_id,
      content_type: :text
    )
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.info "[BAILEYS] Duplicate message #{@message_source_id}, skipping"
  end
end
