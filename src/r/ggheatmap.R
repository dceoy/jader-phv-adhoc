# coding: utf-8

sapply(c('data.table', 'ggplot2'), function(p) require(p, character.only = TRUE))

mtx <- fread('matrix.csv')

heatmap <- ggplot(mtx, aes(x = col, y = row, fill = val)) +
             geom_tile() +
             scale_fill_gradient(trans = 'log', breaks = c(10, 100, 1000), low = 'grey', high = 'blue', na.value='#FFFFFF') +
             labs(x = 'column name', y = 'row name')
#            scale_x_discrete(expand = c(0, 0), limits = col_order) +
#            scale_y_discrete(expand = c(0, 0), limits = row_order) +
#            theme(axis.ticks = element_blank(), axis.text.x = element_text(size = 4, angle = 270, hjust = 0, colour = '#000000'))

svg('plot.svg', width = 12, height = 8)
print(heatmap)
dev.off()
