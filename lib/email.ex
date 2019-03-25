defmodule Auth.Email do
  use Bamboo.Phoenix, view: Auth.EmailView

  def send_test_email(to_email_address, subject, message) do
    new_email()
    # also needs to be a validated email
    |> from("nelson@dwyl.io")
    |> to(to_email_address)
    |> subject(subject)
    |> text_body(message)
  end

  def send_test_html_email(to_email_address, subject, link) do
    new_email()
    # also needs to be a validated email
    |> from("cleo@dwyl.com")
    |> to(to_email_address)
    |> subject(subject)
    |> html_body(EEx.eval_file("./lib/auth_web/templates/html_email/email.html.eex"))
  end
end
