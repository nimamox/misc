function imgs = autoenc(ker1, ker2, command, dataset)
    if strcmp(command, 'recons')
        cmd = ['/usr/local/bin/python3  /Users/nima/VTCoursesECE/DigComm/Course_Project/python_src/autoenc_test1.py ' int2str(ker1) ' ' int2str(ker2) ' ' command ' dummy']
        save('/tmp/tmp_mat_py.mat', 'dataset');
        system(cmd)
    else
        cmd = ['/usr/local/bin/python3  /Users/nima/VTCoursesECE/DigComm/Course_Project/python_src/autoenc_test1.py ' int2str(ker1) ' ' int2str(ker2) ' ' command ' ' dataset]
        system(cmd)
        imgs = load('/tmp/tmp_py_mat.mat').data;
    end
    imgs = load('/tmp/tmp_py_mat.mat').data;
%     
end