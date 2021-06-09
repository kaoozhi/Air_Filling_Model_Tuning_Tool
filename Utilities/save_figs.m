function save_figs(tt)
    savefig(tt);
    saveas(gcf, [tt '.jpg']);
end