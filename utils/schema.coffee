mongoose = require("mongoose")

site_stats_schema = mongoose.Schema
  codebase: String
  build_succeeds: Boolean
  unmerged_branches: [{remote: String, branch: String}]
  js_log_lines: Number
  total_lines_of_code: Object

exports.SiteStats = mongoose.model('SiteStats', site_stats_schema)
