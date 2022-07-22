/*
 * procfs1.c
 */

#include <linux/kernel.h>		/* We're doing kernel work */
#include <linux/module.h>		/* Specifically, a module */
#include <linux/proc_fs.h>		/* Necessary because we use the proc fs */
#include <linux/uaccess.h>		/* for copy_from_user */
#include <linux/version.h>

#if LINUX_VERSION_CODE >= KERNEL_VERSION(5, 6, 0)
#define HAVE_PROC_OPS
#endif

#if LINUX_VERSION_CODE < KERNEL_VERSION(3, 10, 0)
#define HAVE_PROC_READ_SUITE
#endif

#define PROCFS_MAX_SIZE		(1024*8)
#define PROCFS_NAME			"pbuf"

/* This structure hold information about the /proc file */
static struct proc_dir_entry *our_proc_file;

/* The buffer used to store character for this module */
static char procfs_buffer[PROCFS_MAX_SIZE];
/* The size of the buffer */
static unsigned long procfs_buffer_size = 0;

static ssize_t procfile_read(struct file *file, const char __user *buff,
                             size_t len, loff_t *off)
{
	size_t count = len, data_length = sizeof(procfs_buffer);
    ssize_t retval = 0;
    unsigned long ret = 0;

    if (*off >= data_length)
        goto out;
    if (*off + len > data_length)
        count = data_length - *off;

    /* ret contains the amount of chars wasn't successfully written to `buf` */
    ret = copy_to_user(buff, procfs_buffer + *off, count);
    *off += count - ret;
    retval = count - ret;

out:
    return retval;
}

/*
cat /dev/zero | tr "\0" "a" | dd of=/tmp/1.txt bs=1023 count=1
cat /tmp/1.txt > /proc/pbuf
*/
static ssize_t procfile_write(struct file *file, const char __user *buff,
                              size_t len, loff_t *off)
{
	unsigned long write_size = len;
	unsigned long left_size = PROCFS_MAX_SIZE - procfs_buffer_size;

    if (write_size > left_size)
        write_size = left_size;

	if (copy_from_user(procfs_buffer + procfs_buffer_size, buff, write_size)) {
		pr_info("copy_from_user failed\n");
        return -EFAULT;
	}

	pr_info("procfile write offset %lu with length %lu\n", procfs_buffer_size, write_size);
	procfs_buffer_size += write_size;
	*off += write_size;

    return write_size;
}

#ifdef HAVE_PROC_OPS
static const struct proc_ops proc_file_fops = {
    .proc_read = procfile_read,
	.proc_write = procfile_write,
};
#else
static const struct file_operations proc_file_fops = {
    .read = procfile_read,
	.write = procfile_write,
};
#endif

static int __init procfs1_init(void)
{
    our_proc_file = proc_create(PROCFS_NAME, 0644, NULL, &proc_file_fops);
    if (NULL == our_proc_file) {
#ifdef HAVE_PROC_READ_SUITE
		remove_proc_entry(PROCFS_NAME, NULL);
#else
        proc_remove(our_proc_file);
#endif
        pr_alert("Error:Could not initialize /proc/%s\n", PROCFS_NAME);
        return -ENOMEM;
    }

    pr_info("/proc/%s created\n", PROCFS_NAME);
    return 0;
}

static void __exit procfs1_exit(void)
{
#ifdef HAVE_PROC_READ_SUITE
		remove_proc_entry(PROCFS_NAME, NULL);
#else
        proc_remove(our_proc_file);
#endif
    pr_info("/proc/%s removed\n", PROCFS_NAME);
}

module_init(procfs1_init);
module_exit(procfs1_exit);

MODULE_LICENSE("GPL");
