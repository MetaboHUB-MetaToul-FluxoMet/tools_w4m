import { Compiler, Stats } from 'webpack';
interface IPluginOptions {
    filename: string;
    prepare: (stats: Stats) => {
        [k: string]: any;
    };
}
export declare type UserOptions = Partial<IPluginOptions>;
export declare class DumpMetaPlugin {
    options: IPluginOptions;
    constructor(options?: UserOptions);
    apply(compiler: Compiler): void;
}
export {};
