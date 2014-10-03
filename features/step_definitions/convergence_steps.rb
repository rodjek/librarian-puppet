Then /^the file "([^"]*)" should have an inode and ctime$/ do |file|
    prep_for_fs_check do
        stat = File.stat(File.expand_path(file))
        @before_inode = { 'ino' => stat.ino, 'ctime' => stat.ctime }
        expect(@before_inode['ino']).not_to eq nil
        expect(@before_inode['ctime']).not_to eq nil
    end
end

Then /^the file "([^"]*)" should have the same inode and ctime as before$/ do |file|
    prep_for_fs_check do
        stat = File.stat(File.expand_path(file))
        expect(stat.ino).to eq @before_inode['ino']
        expect(stat.ctime).to eq @before_inode['ctime']
    end
end

Then /^the file "([^"]*)" should not have the same inode or ctime as before$/ do |file|
    prep_for_fs_check do
        stat = File.stat(File.expand_path(file))

        begin
            expect(stat.ino).not_to eq @before_inode['ino']
        rescue RSpec::Expectations::ExpectationNotMetError
            expect(stat.ctime).not_to eq @before_inode['ctime']
        end
    end
end
