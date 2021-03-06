# encoding: utf-8
class Notifier < ActionMailer::Base
  include Salva::SiteConfig
  # include Resque::Mailer if File.exist? File.join(Rails.root.to_s, 'config', 'resque.yml')

  default :from => Salva::SiteConfig.system('email')

  def new_user_to_admin(user_id)
    @user =  User.find(user_id)
    mail(:to => email_academic_secretary, :cc => [email_ldap_admin, email_accounts_notification].compact!,
         :subject => 'SALVA - Nuevo usuario') do |format|
      format.text
    end
  end

  def identification_card_request(user_id)
    @user =  User.find(user_id)
    mail(:to => Salva::SiteConfig.teaching_coordination('email'), :cc => email_accounts_notification,
         :subject => 'SALVA - Nuevo usuario') do |format|
      format.text
    end
  end

  def ldap_errors_to_admin(user_id)
    @user = User.find(user_id)
    mail(:to => email_ldap_admin, :cc => email_academic_secretary,
         :subject => 'SALVA - Errores al crear usuario en LDAP') do |format|
      format.text
    end
  end

  def deleted_user_to_admin(login)
    @login = login
    mail(:to => email_academic_secretary, :cc => [email_ldap_admin, email_accounts_notification].compact!,
         :subject => 'SALVA - Usuario borrado') do |format|
      format.text
    end
  end

  def updated_userstatus_to_admin(user_id)
    @user =  User.find(user_id)
    mail(:to => email_academic_secretary, :cc => [email_ldap_admin, email_accounts_notification].compact!,
         :subject => 'SALVA - Estado de usuario actualizado') do |format|
      format.text
    end
  end

  def notification_card_for_postdoctoral(user_id)
    @user =  User.find(user_id)
    mail(:to => @user.email, :cc => email_accounts_notification,
         :subject => 'SALVA - Notificación de credencial actualizada') do |format|
      format.text
    end
  end

  def aleph_notification_for_academic(user_id)
    @user =  User.find(user_id)
    mail(:to => @user.email, :cc => email_accounts_notification,
         :subject => 'SALVA - Notificación de activación de su cuenta en la biblioteca') do |format|
      format.text
    end
  end

  def notification_for_library_admin(user_id)
    @user =  User.find(user_id)
    mail(:to => email_library_admin, :cc => email_accounts_notification,
         :subject => 'SALVA - Usuario agregado o actualizado al sistema ALEPH') do |format|
      format.text
    end
  end
  
  def notification_of_deleted_user_for_library_admin(user_id)
    @user =  User.find(user_id)
    mail(:to => email_library_admin, :cc => email_accounts_notification,
         :subject => 'SALVA - Usuario borrado del sistema ALEPH') do |format|
      format.text
    end
  end

  def aleph_errors_to_library_admin(user_id)
    @user =  User.find(user_id)
    mail(:to => email_library_admin, :cc => email_accounts_notification,
         :subject => 'SALVA - Errores al agregar o actualizar cuenta de usuario en el sistema ALEPH') do |format|
      format.text
    end
  end

  def approved_document(document_id)
    @document = Document.find(document_id)
    filename = File.basename(@document.file) if File.exist? @document.file
    cc = [email_academic_secretary]
    cc.push(@document.approved_by.email) unless @document.approved_by_id.nil?
    mail(:to => @document.user.email, :cc => cc,
         :subject => @document.documenttype.name) do |format|
      format.text
      attachments[filename] = File.read(@document.file) if File.exist? @document.file
    end
  end

  def approval_request_to_user(document_id)
    @document = Document.find(document_id)
    filename = File.basename(@document.file) if File.exist? @document.file
    mail(:to => @document.user.email, :cc => email_academic_secretary,
         :subject => @document.documenttype.name) do |format|
      format.text
      attachments[filename] = File.read(@document.file) if File.exist? @document.file
    end
  end

  def approval_request_to_user_incharge(document_id)
    @document = Document.find(document_id)
    filename = File.basename(@document.file) if File.exist? @document.file
    mail(:to => @document.user.user_incharge.email, :cc => email_academic_secretary,
         :subject => @document.documenttype.name) do |format|
      format.text
      attachments[filename] = File.read(@document.file) if File.exist? @document.file
    end
  end

  def rejected_document(document_id)
    @document = Document.find(document_id)
    mail(:to => @document.user.email, :cc => [email_academic_secretary, @document.approved_by.email].compact!,
         :subject => @document.documenttype.name)
  end

  private
  def email_ldap_admin
    ldap_config = "#{Rails.root.to_s}/config/ldap.yml"
    if File.exist? ldap_config
      YAML.load_file(ldap_config)['admin']['email']
    end
  end
  
  def email_academic_secretary 
    Salva::SiteConfig.academic_secretary('email')
  end

  def email_accounts_notification
    Salva::SiteConfig.accounts_notification('email')
  end
  
  def email_library_admin
    aleph_config = "#{Rails.root.to_s}/config/aleph.yml"
    if File.exist? aleph_config
      YAML.load_file(aleph_config)['notification_email']
    end
  end
end
