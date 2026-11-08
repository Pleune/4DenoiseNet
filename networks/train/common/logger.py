# Logging using torch.utils.tensorboard (no TensorFlow dependency)
# Replaces the old TF 1.x logger

import numpy as np
from torch.utils.tensorboard import SummaryWriter
import torch
from io import BytesIO
import matplotlib.pyplot as plt


class Logger(object):

    def __init__(self, log_dir):
        """Create a summary writer logging to log_dir."""
        self.writer = SummaryWriter(log_dir)

    def scalar_summary(self, tag, value, step):
        """Log a scalar variable."""
        self.writer.add_scalar(tag, value, step)
        self.writer.flush()

    def image_summary(self, tag, images, step):
        """Log a list of images."""
        for i, img in enumerate(images):
            if isinstance(img, np.ndarray):
                # Convert numpy to tensor, ensure correct shape (C,H,W)
                if img.ndim == 3 and img.shape[-1] in (1, 3, 4):
                    img_t = torch.from_numpy(img).permute(2, 0, 1)
                elif img.ndim == 2:
                    img_t = torch.from_numpy(img).unsqueeze(0)
                else:
                    img_t = torch.from_numpy(img)
            else:
                img_t = img
            self.writer.add_image(f'{tag}/{i}', img_t, step)
        self.writer.flush()

    def histo_summary(self, tag, values, step, bins=1000):
        """Log a histogram of the tensor of values."""
        if isinstance(values, np.ndarray):
            values_t = torch.from_numpy(values)
        else:
            values_t = values
        self.writer.add_histogram(tag, values_t, step)
        self.writer.flush()