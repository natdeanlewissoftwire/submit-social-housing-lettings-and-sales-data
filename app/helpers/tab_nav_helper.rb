module TabNavHelper
  include GovukLinkHelper

  def user_cell(user)
    link_text = user.name.presence || user.email
    [govuk_link_to(link_text, user), "<span class=\"govuk-visually-hidden\">User </span><span class=\"govuk-!-font-weight-regular app-!-colour-muted\">#{user.email}</span>"].join("\n")
  end

  def location_cell_postcode(location, link)
    link_text = location.postcode || "Add postcode"
    [govuk_link_to(link_text, link, method: :patch), "<span class=\"govuk-visually-hidden\">Location</span>"].join("\n")
  end

  def scheme_cell(scheme)
    link_text = scheme.service_name
    link = scheme.confirmed? ? scheme : scheme_check_answers_path(scheme)
    [govuk_link_to(link_text, link), "<span class=\"govuk-visually-hidden\">Scheme</span>"].join("\n")
  end

  def org_cell(user)
    role = "<span class=\"app-!-colour-muted\">#{user.role.to_s.humanize}</span>"
    [user.organisation.name, role].join("\n")
  end
end
