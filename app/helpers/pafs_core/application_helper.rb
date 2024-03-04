# frozen_string_literal: true

module PafsCore
  module ApplicationHelper
    def pafs_form_for(name, *args, &)
      options = args.extract_options!

      content_tag(:div,
                  form_for(name, *(args << options.merge(builder: GOVUKDesignSystemFormBuilder::FormBuilder)), &),
                  class: "pafs_form")
    end

    def month_and_year(form, project, attribute, options = {})
      m_key = :"#{attribute}_month"
      y_key = :"#{attribute}_year"
      contents = []
      contents << heading_text(options.delete(:heading)) if options.include? :heading
      contents << content_tag(:p, options.delete(:hint), class: "govuk-hint") if options.include? :hint
      # need to handle the 2 fields as one for errors
      contents << error_message(form.object, project, attribute)
      contents << content_tag(:div, class: "form-date") do
        safe_join([
                    content_tag(:div, class: "form-group form-group-month") do
                      form.govuk_number_field(
                        m_key,
                        width: 2, maxlength: 2, min: 1, max: 12,
                        label: { text: t("month_label") },
                        class: "form-group-month"
                      )
                    end,
                    content_tag(:div, class: "form-group form-group-year") do
                      form.govuk_number_field(
                        y_key,
                        width: 3, maxlength: 4, min: 2000, max: 2100,
                        label: { text: t("year_label") },
                        class: "form-group-year"
                      )
                    end
                  ], "\n")
      end

      safe_join(contents, "\n")
    end

    def error_message(object, prefix, attribute)
      return unless object.errors.include? attribute

      content = []
      object.errors.full_messages_for(attribute).each do |message|
        content << content_tag(:p, trim_error_message(attribute, message),
                               class: "govuk-error-message",
                               id: error_id(prefix, attribute))
      end
      safe_join(content, "\n")
    end

    def error_id(prefix, attribute)
      "#{attr_name(prefix, attribute).dasherize}-field-error"
    end

    # This is a workaround to allow the legacy PAFS error setup to work with GOVUK FormBuilder error handling.
    def trim_error_message(attribute, message)
      message.delete_prefix(attribute.to_s.humanize)
    end

    def form_group(object, name, attribute, other_class = nil, &)
      attribute_error = object.errors.include?(attribute)
      id = content_id(name, attribute.to_sym, attribute_error)
      content_tag(:div,
                  id: id,
                  class: error_class(object, attribute, "govuk-form-group #{other_class || ''}"),
                  aria_described_by: id) do
        if attribute_error
          content_tag(:p, class: "govuk-error-message", id: "#{id}-error") do
            content_tag(:span, class: "govuk-visually-hidden") { "Error: " }
          end
        end
        content_tag(:div, &) if block_given?
      end
    end

    def content_id(form, attribute, attribute_error)
      "#{form}-#{attribute}#{attribute_error ? '-error' : ''}".dasherize
    end

    def error_class(object, attribute, default_classes)
      "#{default_classes || ''} #{object.errors.include?(attribute.to_sym) ? 'govuk-form-group--error' : 'no-error'}"
    end

    def attr_name(object_name, attribute)
      "#{object_name}-#{attribute}"
    end

    def govuk_checkbox_for(form, attribute, scope = ".", unchecked_value = 0)
      form.govuk_check_box(
        attribute,
        attribute,
        unchecked_value,
        label: { text: t(attribute, scope: scope) },
        multiple: false
      )
    end

    def title
      title_elements = [error_title, title_text, t(:global_proposition_header), "GOV.UK"]
      # Remove empty elements, for example if no specific title is set
      title_elements.compact_blank!
      title_elements.join(" - ")
    end

    # we're not including Devise in the engine so the current_user
    # will not be available unless brought in via the application using this
    # engine (might not even be current_user ...)
    def current_resource
      resource = nil
      if Object.const_defined?("Devise")
        Devise.mappings.each_value do |m|
          resource = send("current_#{m.name}") if send("#{m.name}_signed_in?")
        end
      end
      resource
    end

    # Sortable columns helper method: this one just takes the current sort order (asc or desc) and
    # returns the appropriate html entity code for the arrow to display.
    def get_arrow(curr_sort_order)
      if curr_sort_order == "desc"
        "&#9660;"
      else
        "&#9650;" # default is ascending which is the up arrow.
      end
    end

    # Sortable columns helper method: this one works out the sort properties to
    # associate with the column, specifically the next sort order and
    # the sort order denoting arrow to display on the page.
    # The next sort order to associate with this column (this_col),
    # is worked out assuming that:
    # 1 the default sort order for a currently unsorted column should be ascending
    # 2 if this column is the currently sorted column then the sort order should be reversed
    # (this is intended to support usage where-by a user inverts the sort order of a column
    # by re-clicking on a link)
    # 3 If no columns are currently sorted but this column is the default sort column
    # then the column should have the same sort properties as if it was the currently sorted column
    # It also works out the arrow to display assuming that:
    # 1 The arrow denotes the current sort order.
    # 2 The arrow points up for asc, meaning smallest values first.
    # 3 The arrow points down for desc, meaning smallest values last.
    # 4 If a column is not the currently sorted column (or the default sortable column if
    # no other columns are sorted) then no arrow should be displayed at all.
    def get_next_sort_order_and_curr_arrow(current_sorted_col, this_col, curr_sort_order,
                                           default_sort_col, default_sort_order)
      # Assuming that, if no user-defined sorts have yet been run, the system has already applied
      # any default sort properties.

      if current_sorted_col.nil? &&
         !default_sort_col.nil? &&
         default_sort_col == this_col
        current_sorted_col = this_col
        curr_sort_order = default_sort_order
      end

      curr_sort_order = "asc" if curr_sort_order.nil?
      if current_sorted_col == this_col
        # NB what's going to be written to the link is the next sort order,
        # which is the inverse of the current sort order
        arrow = get_arrow(curr_sort_order)
        next_sort_order = if curr_sort_order == "asc"
                            "desc"
                          else
                            "asc" # Default sort order is ascending
                          end
      else
        arrow = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" # Not the currently sorted column, so display no arrow.
        next_sort_order = "asc" # Starting sort order should be asc
      end
      { next_sort_order: next_sort_order, curr_arrow: arrow }
    end

    private

    def title_text
      # Check if the title is set in the view (we do this for High Voltage pages)
      return content_for :title if content_for?(:title)

      # Otherwise, look up translation key based on controller path, action name and .title
      # Solution from https://coderwall.com/p/a1pj7w/rails-page-titles-with-the-right-amount-of-magic
      title = t("#{controller_path.tr('/', '.')}.#{action_name}.title", default: "")
      return title if title.present?

      # Default to title for "new" action if the current action doesn't return anything
      t("#{controller_path.tr('/', '.')}.new.title", default: "")
    end

    def error_title
      content_for :error_title if content_for?(:error_title)
    end

  end
end
