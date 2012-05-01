Dir.chdir Coresys.formula do
  silent_system 'git', 'pull', '--rebase', 'origin', 'refs/heads/master:refs/remotes/origin/master'
  diff = captured_system('git', 'diff-tree', '-r', '--minimal', '--no-color', '--name-status', '--diff-filter=ADMR', 'HEAD@{1}', 'HEAD')

  diff.lines.map(&:split).group_by(&:first).each do |type, changed|
    title = case type
    when 'A' then 'Added'
    when 'D' then 'Deleted'
    when 'M' then 'Updated'
    when 'R' then 'Renamed'
    end + ' formula'

    changed.map! { |formula| formula.last.sub(/\.rb$/, '') }
    columned title, changed
  end
end
