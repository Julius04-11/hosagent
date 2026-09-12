export interface ActivityDetail {
  activityId: number;
  title: string;
  carouselImages: string[];
  sections: Section[];
  enrollmentAvailable: boolean;
  enrollmentText: string;
  enrollmentLink: string;
  // 语音讲解音频资源路径（可选，相对于rawfile目录）
  audioResource?: string;
  // 活动位置信息（可选）
  location?: ActivityLocation;
}

export interface ActivityLocation {
    latitude: number;
    longitude: number;
    address?: string;
}

type Section =
  | TextSection
  | RichTextListSection
  | ImageGallerySection
  | ContactInfoSection;

interface TextSection {
  type: "text";
  title: string;
  content: string;
}

interface RichTextListItem {
  label: string;
  value: string | string[];
}

interface RichTextListSection {
  type: "rich_text_list";
  title: string;
  items: RichTextListItem[];
}
interface ImageGallerySection {
  type: "image_gallery";
  title: string;
  images: string[];
}

interface ContactInfoSection {
  type: "contact_info";
  title: string;
  phone: string;
  email: string;
  website: string;
}

export interface MessageModel {
  type: string;
  content: string;
}

export class routerParams {
  src: string
  constructor(str:string) {
    this.src = str;
  }
}
