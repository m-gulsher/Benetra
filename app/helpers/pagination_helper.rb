module PaginationHelper
  def pagination_links(collection, options = {})
    return "" if @total_pages.nil? || @total_pages <= 1

    page = @current_page || 1
    per_page = @per_page || 20
    total_pages = @total_pages || 1

    url_params = request.query_parameters.dup
    url_params.delete("page")

    links = []

    # Previous link
    if page > 1
      url_params[:page] = page - 1
      links << link_to("← Previous", url_for(url_params), class: "px-3 py-2 border rounded hover:bg-gray-100")
    else
      links << content_tag(:span, "← Previous", class: "px-3 py-2 border rounded text-gray-400 cursor-not-allowed")
    end

    # Page numbers
    start_page = [page - 2, 1].max
    end_page = [page + 2, total_pages].min

    if start_page > 1
      url_params[:page] = 1
      links << link_to("1", url_for(url_params), class: "px-3 py-2 border rounded hover:bg-gray-100")
      links << content_tag(:span, "...", class: "px-2") if start_page > 2
    end

    (start_page..end_page).each do |p|
      if p == page
        links << content_tag(:span, p, class: "px-3 py-2 border rounded bg-blue-500 text-white")
      else
        url_params[:page] = p
        links << link_to(p, url_for(url_params), class: "px-3 py-2 border rounded hover:bg-gray-100")
      end
    end

    if end_page < total_pages
      links << content_tag(:span, "...", class: "px-2") if end_page < total_pages - 1
      url_params[:page] = total_pages
      links << link_to(total_pages, url_for(url_params), class: "px-3 py-2 border rounded hover:bg-gray-100")
    end

    # Next link
    if page < total_pages
      url_params[:page] = page + 1
      links << link_to("Next →", url_for(url_params), class: "px-3 py-2 border rounded hover:bg-gray-100")
    else
      links << content_tag(:span, "Next →", class: "px-3 py-2 border rounded text-gray-400 cursor-not-allowed")
    end

    content_tag(:div, links.join.html_safe, class: "flex items-center space-x-2 mt-4 justify-center")
  end

  def pagination_info(collection)
    return "" if @total_count.nil?

    page = @current_page || 1
    per_page = @per_page || 20
    start = ((page - 1) * per_page) + 1
    finish = [page * per_page, @total_count].min

    content_tag(:div, "Showing #{start}-#{finish} of #{@total_count} records", class: "text-sm text-gray-600 mt-2")
  end
end
