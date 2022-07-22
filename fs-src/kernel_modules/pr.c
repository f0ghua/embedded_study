#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>
#include <linux/kernel.h>   
#include <linux/proc_fs.h>
#include <asm/uaccess.h>

#define HAS_CREATE_PROC_ENTRY
#define BUFSIZ  (1024*8)

MODULE_AUTHOR("Fog Hua");
MODULE_DESCRIPTION("procfs test module.");
MODULE_LICENSE("GPL");

#define PROCNAME "pfs_test"
static struct proc_dir_entry *myproc_entry = NULL;
static char output_data[BUFSIZ] = {[0 ... BUFSIZ-1] = 'a'};

static int read_proc_start_is_null(char *page,
                                   char **start,
                                   off_t offset,
                                   int count,
                                   int *eof,
                                   void *data)
{
	int len = sizeof(output_data);;

	if (count > (len - offset)) {
		count = len - offset;
	}
	memcpy(page + offset, output_data + offset, count);
	if (len <= offset + count) {
		*eof = 1;
	}
	return (offset+count);
}

static int read_proc_start_less_page(char *page,
                                     char **start,
                                     off_t offset,
                                     int count,
                                     int *eof,
                                     void *data)
{
	int len = sizeof(output_data);
	unsigned long copy_len;
	int left_len = len - offset;

	if (offset >= len) return 0;
	if (left_len <= count) *eof = 1;

	copy_len = (left_len <= count)?left_len:count;
	memcpy(page, output_data + offset, copy_len);
	*start = copy_len;
	return (copy_len);
}

static int read_proc_start_in_page(char *page,
                                   char **start,
                                   off_t offset,
                                   int count,
                                   int *eof,
                                   void *data)
{
	int len = sizeof(output_data);
	unsigned long copy_len;
	int left_len = len - offset;

	if (offset >= len) return 0;
	if (left_len <= count) *eof = 1;

	*start = page + 2048;
	copy_len = (left_len <= count)?left_len:count;
	memcpy(*start, output_data + offset, copy_len);

	return (copy_len);
}

static int read_method4(char *page,
                        char **start,
                        off_t offset,
                        int count,
                        int *eof,
                        void *data)
{
	int len = sizeof(output_data);
	int copy_len = 3072;

	if (offset >= sizeof(output_data)) {
		*eof = 1;
		return 0;
	}
	memcpy(page, output_data + offset, copy_len);
	*start = copy_len;
	return (copy_len);
}

static ssize_t procfile_read(struct file *filep, char __user *buf,
                size_t len, loff_t *offp)
{
    size_t count = len, internal_data_len = sizeof(output_data);
    ssize_t retval = 0;
    unsigned long ret = 0;

    if (*offp >= internal_data_len)
        goto out;
    if (*offp + len > internal_data_len)
        count = internal_data_len - *offp;

    /* ret contains the amount of chars wasn't successfully written to `buf` */
    ret = copy_to_user(buf, output_data, count);
    *offp += count - ret;
    retval = count - ret;

out:
    return retval;
}

#ifdef HAVE_PROC_OPS
static const struct proc_ops proc_file_fops = {
    .proc_read = procfile_read,
};
#else
static const struct file_operations proc_file_fops = {
    .read = procfile_read,
};
#endif

static int simple_module_init(void)
{
	int i = 0, len = 0;
	for (i; len < sizeof(output_data); i++) {
		len += snprintf(output_data+len, sizeof(output_data)-len, "%04x", i);
	}

#ifdef HAS_CREATE_PROC_ENTRY
	myproc_entry = create_proc_entry(PROCNAME, 0666, NULL);
	if(!myproc_entry){
		printk(KERN_ERR "can't create /proc/%s\n", PROCNAME);
		return -EFAULT;
	}

	myproc_entry->read_proc = read_method4;
#else
	myproc_entry = proc_create(PROCNAME, 0644, NULL, &proc_file_fops);
    if (NULL == myproc_entry) {
        remove_proc_entry(PROCNAME,NULL);
        pr_alert("Error:Could not initialize /proc/%s\n", PROCNAME);
        return -ENOMEM;
    }
#endif

	return 0;
}

static void simple_module_cleanup(void)
{
	remove_proc_entry(PROCNAME,NULL);
}

module_init(simple_module_init);
module_exit(simple_module_cleanup);
